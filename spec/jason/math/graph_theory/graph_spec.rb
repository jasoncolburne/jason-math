RSpec.describe Jason::Math::GraphTheory::Graph do
  context "#shortest_path" do
    subject { graph.shortest_path(origin, destination) }

    context "stackoverflow example" do
      # example taken from https://stackoverflow.com/questions/30409493/using-bfs-for-weighted-graphs
      let(:origin) { 1 }
      let(:destination) { 5 }
      let(:graph) { described_class.new(vertices) }
      let(:vertices) { [1, 2, 3, 4, 5, 6] }

      before do
        graph.add_edge(1, 2, 7)
        graph.add_edge(1, 3, 9)
        graph.add_edge(1, 6, 14)
        graph.add_edge(2, 3, 10)
        graph.add_edge(2, 4, 15)
        graph.add_edge(3, 4, 11)
        graph.add_edge(3, 6, 2)
        graph.add_edge(4, 5, 6)
        graph.add_edge(6, 5, 9)
      end

      it { is_expected.to eq(20) }
    end
  end

  context "#longest_path" do
    subject { graph.longest_path(origin, destination) }

    context "for some graph" do
      # unverified
      let(:origin) { 1 }
      let(:destination) { 5 }
      let(:graph) { described_class.new(vertices) }
      let(:vertices) { [1, 2, 3, 4, 5, 6] }

      before do
        graph.add_edge(1, 2, 7)
        graph.add_edge(1, 3, 9)
        graph.add_edge(1, 6, 14)
        graph.add_edge(2, 3, 10)
        graph.add_edge(2, 4, 15)
        graph.add_edge(3, 4, 11)
        graph.add_edge(3, 6, 2)
        graph.add_edge(4, 5, 6)
        graph.add_edge(6, 5, 9)
      end

      it { is_expected.to eq(34) }
    end
  end

  context "#minimum_spanning_tree" do
    subject { graph.minimum_spanning_tree }

    # https://www.techiedelight.com/kruskals-algorithm-for-finding-minimum-spanning-tree/
    context "for techiedelight example" do
      let(:graph) { described_class.new(vertices) }
      let(:vertices) { [0, 1, 2, 3, 4, 5, 6] }

      before do
        graph.add_edge(0, 1, 7)
        graph.add_edge(1, 2, 8)
        graph.add_edge(0, 3, 5)
        graph.add_edge(1, 3, 9)
        graph.add_edge(1, 4, 7)
        graph.add_edge(2, 4, 5)
        graph.add_edge(3, 4, 15)
        graph.add_edge(3, 5, 6)
        graph.add_edge(4, 5, 8)
        graph.add_edge(4, 6, 9)
        graph.add_edge(5, 6, 11)
      end

      it do
        is_expected.to eq([
          { origin: 2, destination: 4, weight: 5 },
          { origin: 0, destination: 3, weight: 5 },
          { origin: 3, destination: 5, weight: 6 },
          { origin: 0, destination: 1, weight: 7 },
          { origin: 1, destination: 4, weight: 7 },
          { origin: 4, destination: 6, weight: 9 },
        ])
      end
    end

    context "for disconnected graph" do
      let(:graph) { described_class.new(vertices) }
      let(:vertices) { [0, 1, 2, 3, 4, 5, 6] }

      before do
        graph.add_edge(0, 1, 7)
        graph.add_edge(0, 3, 5)
        graph.add_edge(1, 3, 9)
        graph.add_edge(2, 4, 5)
        graph.add_edge(3, 5, 6)
        graph.add_edge(4, 6, 9)
      end

      it { is_expected.to eq(nil) }
    end
  end
end
